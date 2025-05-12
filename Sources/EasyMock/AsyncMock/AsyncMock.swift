//
// Created by Paolo Prodossimo Lopes
// Open-source utility for Testing - Use freely with attribution.
//

import Foundation

///
/// A mock utility for simulating asynchronous operations with optional delay in unit tests.
///
/// `AsyncMock` é ideal para testar código que utiliza `async/await`, retornando um valor controlado após um possível atraso simulado.
/// Essa classe não lança erros, sendo útil para testar fluxos assíncronos de sucesso, como:
/// - Requisições que retornam com sucesso
/// - Fluxos assíncronos com carregamento (loading)
/// - Códigos que usam `await` com valores conhecidos
///
/// Internamente, `AsyncMock`:
/// - Usa um `Mock` tradicional para gravar entradas e fornecer saídas
/// - Simula atraso com uma instância de `Sleeper`
///
/// ## Quick Example
/// ```swift
/// let mock = AsyncMock<String, Bool>(true)
/// mock.mock(delay: 1.0)
/// let result = await mock.synchronize("loadUser")
/// XCTAssertTrue(result)
/// XCTAssertEqual(mock.spies, ["loadUser"])
/// ```
///
/// ## Complete example
/// ```swift
/// protocol AsyncInterface {
///     func load() async
///     func fetch(id: Int) async
///     func fetchMessage() async -> String
///     func fetchTitle(id: Int) async -> String
/// }
///
/// struct AsyncInterfaceMock: AsyncInterface {
///     let loadMocked = AsyncMock<Void, Void>(())
///     let fetchMocked = AsyncMock<Int, Void>(())
///     let fetchMessageMocked = AsyncMock<Void, String>("default")
///     let fetchTitleMocked = AsyncMock<Int, String>("none")
///
///     func load() {
///         await loadMocked.synchronize()
///     }
///
///     func fetch(id: Int) {
///         await fetchMocked.synchronize(id)
///     }
///
///     func fetchMessage() async -> String {
///         await fetchMessageMocked.synchronize()
///     }
///
///     func fetchTitle(id: Int) async -> String {
///         await fetchTitleMocked.synchronize(id)
///     }
/// }
///
/// let mock = AsyncInterfaceMock()
/// await mock.loadMocked.mock(delay: 0.5)
/// await mock.fetchMessageMocked.mock(returning: "Hello")
/// await mock.fetchTitleMocked.mock(returning: "Swift")
///
/// let message = await mock.fetchMessage()
/// let title = await mock.fetchTitle(id: 1)
///
/// #expect(message == "Hello")
/// #expect(title == "Swift")
/// #expect(mock.fetchTitleMocked.callCount == 1)
/// ```
///
@available(iOS 13.0, *)
@available(macOS 10.15, *)
@available(tvOS 13.0, *)
@available(watchOS 6.0, *)
@available(visionOS 1.0, *)
public final class AsyncMock<Input, Output>: @unchecked Sendable {

    // MARK: - Private Properties

    private let mocked: Mock<Input, Output>
    private var sleeper = Sleeper()

    // MARK: - Initialization

    ///
    /// Cria um mock assíncrono com um valor inicial de retorno.
    ///
    /// - Parameter initialValue: Valor padrão a ser retornado pelas chamadas.
    ///
    public init(_ initialValue: Output) {
        self.mocked = Mock(initialValue)
    }

    // MARK: - Public Properties

    ///
    /// Valor atual que será retornado pelas chamadas de `synchronize`.
    ///
    public var returnValue: Output {
        mocked.returnValue
    }

    ///
    /// Lista de entradas registradas por chamadas anteriores.
    ///
    public var spies: [Input] {
        mocked.spies
    }

    ///
    /// Quantidade de vezes que `synchronize` foi chamado.
    ///
    public var callCount: Int {
        mocked.callCount
    }

    ///
    /// Indica se o mock já foi chamado ao menos uma vez.
    ///
    public var wasCalled: Bool {
        mocked.wasCalled
    }

    // MARK: - Behavior

    ///
    /// Simula uma chamada assíncrona:
    /// - Registra a entrada
    /// - Aguarda (caso delay esteja configurado)
    /// - Retorna o valor configurado
    ///
    /// - Parameter input: Valor de entrada a ser registrado.
    /// - Returns: Valor atualmente configurado em `returnValue`.
    ///
    /// - Example:
    /// ```swift
    /// let mock = AsyncMock<String, Int>(1)
    /// mock.mock(delay: 2.0)
    /// let result = await mock.synchronize("ping") // Após 2s, retorna 1
    /// ```
    ///
    @discardableResult
    public func synchronize(_ input: Input) async -> Output {
        let output = mocked.synchronize(input)
        try? await sleeper.wait()
        return output
    }

    ///
    /// Configura um atraso (em segundos) antes de retornar o valor.
    ///
    /// - Parameter delay: Duração do atraso artificial.
    ///
    /// - Example:
    /// ```swift
    /// mock.mock(delay: 0.3) // adiciona 300ms de simulação
    /// ```
    ///
    public func mock(delay: Double) {
        sleeper.set(delay)
    }

    ///
    /// Define um novo valor de retorno para as chamadas.
    ///
    /// - Parameter output: Valor que será retornado pelas próximas chamadas de `synchronize`.
    ///
    public func mock(returning output: Output) {
        mocked.mock(returning: output)
    }

    // MARK: - Observation

    ///
    /// Adiciona um observador que será chamado com o valor de entrada a cada chamada.
    ///
    /// - Parameter completion: Closure que recebe o input.
    ///
    public func observe(_ completion: @escaping ((Input) -> Void)) {
        mocked.observe(completion)
    }

    ///
    /// Adiciona um observador que será chamado em toda chamada, independentemente do input.
    ///
    /// - Parameter completion: Closure a ser executada.
    ///
    public func observe(_ completion: @escaping (() -> Void)) {
        mocked.observe(completion)
    }
}
